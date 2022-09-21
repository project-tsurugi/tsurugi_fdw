#include "command/drop_command.h"

#ifdef __cplusplus
extern "C" {
#endif
#include "nodes/parsenodes.h"
#ifdef __cplusplus
}
#endif

class DropTable : public DropCommand {
 public:
	DropTable(DropStmt* drop_stmt) : DropCommand(drop_stmt) {}

	/**
	 * @brief
	 */
	virtual bool validate_syntax() const {
		DropStmt* drop_stmt = this->drop_stmt();
		assert(drop_stmt != nullptr);
		bool result{false};

		if (drop_stmt->behavior == DROP_CASCADE) {
			ereport(ERROR,
					(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
					errmsg("Tsurugi does not support CASCADE clause")));
			return result;
		}
		result = true;

		return result;
	}

	/**
	 * @brief
	 */
	virtual bool validate_data_type() const { return true; }

	DropTable() = delete;
	DropTable(const DropTable&) = delete;
  	DropTable& operator=(const DropTable&) = delete;
};

