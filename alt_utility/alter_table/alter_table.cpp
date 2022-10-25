/*
 * Copyright 2022 tsurugi project.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 *	@file	alter_table.h
 *	@brief  Create constraint metadata from alter table statement.
 */
#include <memory>
#include <vector>
#include "manager/metadata/tables.h"
#include "manager/metadata/constraints.h"
#include "manager/metadata/metadata_factory.h"

#ifdef __cplusplus
extern "C" {
#endif
#include "postgres.h"
#include "nodes/parsenodes.h"
#ifdef __cplusplus
}
#endif

#include "alter_table.h"

using namespace manager;

/**
 *  @brief  Check if given syntax supported or not by Tsurugi
 *  @return true if supported
 *  @return false otherwise.
 */
bool AlterTable::validate_syntax() const
{

	AlterTableStmt* alter_table_stmt{this->alter_table_stmt()};
	Assert(alter_table_stmt != NULL);
	bool result{true};

	ListCell* listptr;
	foreach(listptr, alter_table_stmt->cmds) {
		Node* node = (Node*) lfirst(listptr);
		if (IsA(node, AlterTableCmd)) {
			AlterTableCmd* cmd = (AlterTableCmd*) node;
			if (IsA(cmd->def, Constraint)) {
				Constraint* constr = (Constraint*) cmd->def;
				if (constr->fk_del_action == FKCONSTR_ACTION_CASCADE) {
					ereport(ERROR,
						(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
						errmsg("Tsurugi does not support CASCADE action")));
					result = false;
					return result;
				}
				if (constr->fk_upd_action == FKCONSTR_ACTION_CASCADE) {
					ereport(ERROR,
						(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
						errmsg("Tsurugi does not support CASCADE action")));
					result = false;
					return result;
				}
			}
		}
	}
	return result;
}

/**
 * @brief	Get check constraint information.
 * @param 	constr [in] column query tree.
 * @param 	table [in] table metadata.
 * @param 	column_def [in] column query tree.
 * @param 	constraint [out] constraint metadata.
 * @return 	true if success, otherwise fault.
 */
bool AlterTable::get_constraint_metadata(Constraint* constr, 
							metadata::Table& table, 
							metadata::Constraint& constraint) const
{
	bool result{false};

	if (constr->contype == CONSTR_FOREIGN) {
		auto tables = metadata::get_table_metadata("tsurugi");
		metadata::ErrorCode error = metadata::ErrorCode::NOT_FOUND;

		/* put constraint name metadata */
		if (constr->conname != NULL) {
			constraint.name = constr->conname;
		}

		/* put constraint type metadata */
		constraint.type = metadata::Constraint::ConstraintType::FOREIGN_KEY;

		/* put constraint columns and columns_id metadata */
		ListCell* listptr;
		foreach(listptr, constr->fk_attrs) {
			Node* node = (Node*) lfirst(listptr);
			if (IsA(node, String)) {
				bool column_exitst{false};
				for (const auto& column : table.columns) {
					if (column.name == strVal(node)) {
						column_exitst = true;
						constraint.columns.emplace_back(column.column_number);
						constraint.columns_id.emplace_back(column.id);
					}
				}
				if (!column_exitst) {
					error = tables->remove(table.id);
					if (error != metadata::ErrorCode::OK) {
						ereport(ERROR,
								(errcode(ERRCODE_INTERNAL_ERROR),
								errmsg("Remove a table metadata failed when registing constraints. " \
								"(name: %s) (error:%d)", table.name.data(), (int) error)));
						return result;
					}
					ereport(ERROR,
							(errcode(ERRCODE_INVALID_TABLE_DEFINITION),
							errmsg("column \"%s\" referenced in foreign key constraint does not exist",
							(char*) strVal(node))));
					return result;
				}
			}
		}

		/* put constraint pk_table metadata */
		metadata::Table pk_table;
		RangeVar* pktable = (RangeVar*) constr->pktable;
		error = tables->get(pktable->relname, pk_table);
		if (error != metadata::ErrorCode::OK) {
			error = tables->remove(table.id);
			if (error != metadata::ErrorCode::OK) {
				ereport(ERROR,
						(errcode(ERRCODE_INTERNAL_ERROR),
						errmsg("Remove a table metadata failed when registing constraints. " \
						"(name: %s) (error:%d)", table.name.data(), (int) error)));
				return result;
			}
			ereport(ERROR,
					(errcode(ERRCODE_INVALID_TABLE_DEFINITION),
					errmsg("relation \"%s\" does not exist",
					(char*) pktable->relname)));
			return result;
		}
		constraint.pk_table = pktable->relname;

		/* put constraint pk_columns and pk_columns_id metadata */
		foreach(listptr, constr->pk_attrs) {
			Node* node = (Node*) lfirst(listptr);
			if (IsA(node, String)) {
				bool column_exitst{false};
				for (const auto& column : pk_table.columns) {
					if (column.name == strVal(node)) {
						column_exitst = true;
						constraint.pk_columns.emplace_back(column.column_number);
						constraint.pk_columns_id.emplace_back(column.id);
					}
				}
				if (!column_exitst) {
					error = tables->remove(table.id);
					if (error != metadata::ErrorCode::OK) {
						ereport(ERROR,
								(errcode(ERRCODE_INTERNAL_ERROR),
								errmsg("Remove a table metadata failed when registing constraints. " \
								"(name: %s) (error:%d)", table.name.data(), (int) error)));
						return result;
					}
					ereport(ERROR,
							(errcode(ERRCODE_INVALID_TABLE_DEFINITION),
							errmsg("column \"%s\" referenced in foreign key constraint does not exist",
							(char*) strVal(node))));
					return result;
				}
			}
		}

		/* put constraint fk_match_type metadata */
		switch (constr->fk_matchtype) {
			case FKCONSTR_MATCH_FULL:
				constraint.fk_match_type = metadata::Constraint::MatchType::FULL;
				break;
			case FKCONSTR_MATCH_PARTIAL:
				constraint.fk_match_type = metadata::Constraint::MatchType::PARTIAL;
				break;
			case FKCONSTR_MATCH_SIMPLE:
				constraint.fk_match_type = metadata::Constraint::MatchType::SIMPLE;
				break;
			default:
				constraint.fk_match_type = metadata::Constraint::MatchType::UNKNOWN;
				break;
		}

		/* put constraint fk_delete_action metadata */
		switch (constr->fk_del_action) {
			case FKCONSTR_ACTION_NOACTION:
				constraint.fk_delete_action = metadata::Constraint::ActionType::NO_ACTION;
				break;
			case FKCONSTR_ACTION_RESTRICT:
				constraint.fk_delete_action = metadata::Constraint::ActionType::RESTRICT;
				break;
			case FKCONSTR_ACTION_CASCADE:
				constraint.fk_delete_action = metadata::Constraint::ActionType::CASCADE;
				break;
			case FKCONSTR_ACTION_SETNULL:
				constraint.fk_delete_action = metadata::Constraint::ActionType::SET_NULL;
				break;
			case FKCONSTR_ACTION_SETDEFAULT:
				constraint.fk_delete_action = metadata::Constraint::ActionType::SET_DEFAULT;
				break;
			default:
				constraint.fk_delete_action = metadata::Constraint::ActionType::UNKNOWN;
				break;
		}

		/* put constraint fk_update_action metadata */
		switch (constr->fk_upd_action) {
			case FKCONSTR_ACTION_NOACTION:
				constraint.fk_update_action = metadata::Constraint::ActionType::NO_ACTION;
				break;
			case FKCONSTR_ACTION_RESTRICT:
				constraint.fk_update_action = metadata::Constraint::ActionType::RESTRICT;
				break;
			case FKCONSTR_ACTION_CASCADE:
				constraint.fk_update_action = metadata::Constraint::ActionType::CASCADE;
				break;
			case FKCONSTR_ACTION_SETNULL:
				constraint.fk_update_action = metadata::Constraint::ActionType::SET_NULL;
				break;
			case FKCONSTR_ACTION_SETDEFAULT:
				constraint.fk_update_action = metadata::Constraint::ActionType::SET_DEFAULT;
				break;
			default:
				constraint.fk_update_action = metadata::Constraint::ActionType::UNKNOWN;
				break;
		}

		result = true;
	}

	return result;
}

/**
 *  @brief  Generate constraint metadata from query tree.
 *  @param 	table [in] table metadata.
 *  @return OK if success, otherwise falut.
 *  @note	Add metadata of CONSTR_FOREIGN.
 */
metadata::ErrorCode 
AlterTable::generate_constraint_metadata(metadata::Table& table) const
{
	AlterTableStmt* alter_table_stmt{this->alter_table_stmt()};
	Assert(alter_table_stmt != NULL);
	metadata::ErrorCode result = metadata::ErrorCode::NOT_FOUND;

	ListCell* listptr;
	foreach(listptr, alter_table_stmt->cmds) {
		Node* node = (Node*) lfirst(listptr);
		if (IsA(node, AlterTableCmd)) {
			AlterTableCmd* cmd = (AlterTableCmd*) node;
			if (IsA(cmd->def, Constraint)) {
				Constraint* constr = (Constraint*) cmd->def;
				metadata::Constraint constraint;
				bool success = get_constraint_metadata(constr, table, constraint);
				if (success) {
					table.constraints.emplace_back(constraint);
					result = metadata::ErrorCode::OK;
				}
			}
		}
	}

	return result;
}
