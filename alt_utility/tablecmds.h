#ifndef TABLECMDS_
#define TABLECMDS_

class TableCommands {
    public:
        bool define_relation(CreateStmt *stmt);

    private:
        const std::string dbname{"Tsurugi"};
        std::unique_ptr<manager::metadata::Metadata> datatypes;
        std::unique_ptr<manager::metadata::Metadata> tables;

        const manager::metadata::ObjectIdType TSURUGI_TYPE_CHAR_ID = 13;
        const manager::metadata::ObjectIdType TSURUGI_TYPE_VARCHAR_ID = 14;

        const int TSURUGI_DIRECTION_DEFAULT = 0;
        const int TSURUGI_DIRECTION_ASC = 1;
        const int TSURUGI_DIRECTION_DESC = 2;

        const int TYPEMOD_NULL_VALUE = -1;

        bool init();
        bool is_type_supported(CreateStmt *stmt);
        bool is_syntax_supported(CreateStmt *stmt);
        bool store_metadata(CreateStmt *stmt);
};

#endif // TABLECMDS_
