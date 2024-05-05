"""Validate that upstream models have data for the interval needed by the downstream model."""

from sqlglot import transpile
from sqlmesh import Snapshot
from sqlmesh.core.macros import MacroEvaluator, macro


@macro()
def verify_upstream_models_have_needed_intervals(evaluator: MacroEvaluator) -> None:
    """Verify that upstream models have data for the interval needed by the downstream model."""
    sql_strings_dialect = "databricks"
    if evaluator.runtime_stage == "evaluating" and evaluator.gateway != "combined":
        start = evaluator.locals["start_ts"]
        end = evaluator.locals["end_ts"]

        this_model_snapshot = evaluator.locals["snapshot"]
        assert isinstance(this_model_snapshot, Snapshot)
        upstream_objects = this_model_snapshot.model.depends_on

        for upstream_object in upstream_objects:
            start_included = evaluator.engine_adapter.fetchone(
                transpile(
                    f"""
                with row_in_start_interval as (
                    select 1 from {upstream_object} where to_timestamp('{start}') between start_ts and end_ts limit 1
                )
                select count(1) = 1 from row_in_start_interval
                """,
                    read=sql_strings_dialect,
                    write=evaluator.engine_adapter.dialect,
                )[0]
            )[0]
            end_included = evaluator.engine_adapter.fetchone(
                transpile(
                    f"""
                with row_in_end_interval as (
                    select 1 from {upstream_object} where to_timestamp('{end}') between start_ts and end_ts limit 1
                )
                select count(1) = 1 from row_in_end_interval
                """,
                    read=sql_strings_dialect,
                    write=evaluator.engine_adapter.dialect,
                )[0]
            )[0]
            if not (start_included and end_included):
                min_start = evaluator.engine_adapter.fetchone(
                    transpile(
                        f"select min(start_ts) from {upstream_object}",
                        read=sql_strings_dialect,
                        write=evaluator.engine_adapter.dialect,
                    )
                )[0]
                max_end = evaluator.engine_adapter.fetchone(
                    transpile(
                        f"select max(end_ts) from {upstream_object}",
                        read=sql_strings_dialect,
                        write=evaluator.engine_adapter.dialect,
                    )
                )[0]

                raise ValueError(
                    f"Model {upstream_object} does not have data for the interval {start} - {end}."
                    f" It only has data for the interval {min_start} - {max_end}"
                )
