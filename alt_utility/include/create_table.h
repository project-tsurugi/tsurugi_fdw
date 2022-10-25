/*
 * Copyright 2019-2020 tsurugi project.
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
 *	@file	create_table.h
 *	@brief  Generate table metadata from create statement.
 */
#pragma once
#include <vector>
#include <unordered_set>
#include <boost/property_tree/ptree.hpp>
#include "command/create_command.h"
#include "manager/metadata/tables.h"

class CreateTable : public CreateCommand {
 public:
	CreateTable(CreateStmt* create_stmt) : CreateCommand(create_stmt) {}

	virtual bool validate_syntax() const override;
	virtual bool validate_data_type() const override;
	virtual bool generate_metadata(manager::metadata::Object& object) const override;
	manager::metadata::ErrorCode generate_constraint_metadata(manager::metadata::Table& table) const;
	/**
	 * @brief
	 */
	const char* get_table_name() const {
		CreateStmt* create_stmt = this->create_stmt();
		Assert(create_stmt != NULL);
		return create_stmt->relation->relname;
	};

	CreateTable() = delete;
	CreateTable(const CreateTable&) = delete;
  	CreateTable& operator=(const CreateTable&) = delete;

 private:
	bool generate_column_metadata(ColumnDef* column_def, 
								int64_t ordinal_position, 
								TupleDesc descriptor,
								manager::metadata::Column& column) const;
	bool get_data_lengths(List* typmods, std::vector<int64_t>& datalengths) const;
	bool get_constraint_metadata(Constraint* constr, 
								manager::metadata::Table& table, 
								ColumnDef* column_def,
								manager::metadata::Constraint& constraint) const;
	char* get_check_expression(Node* expr) const;
	bool get_expr_recurse(Node* expr, StringInfoData* buf) const;
	bool get_column_ref(ColumnRef* cref, StringInfoData* buf) const;
	bool get_a_const(Value *value, StringInfoData* buf) const;
	bool get_aexpr_op(A_Expr* a, StringInfoData* buf) const;
	bool get_bool_expr(BoolExpr* a, StringInfoData* buf) const;
};
