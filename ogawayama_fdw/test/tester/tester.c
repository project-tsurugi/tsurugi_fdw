#include "postgres.h"
#include <stdio.h>

#include "dispatcher.h"
#include "datatype.h"

int main( int argc, char **argv[] )
{
    int i;
    size_t count;
    PG_TYPE type;
    int32 value;

    printf( "tester started.\n" );


    init_stub( "unit_test" );

    get_connection( 1 );

    dispatch_query( "SETLECT * FROM table;" );    


    count = resultset_get_column_count();
    printf( "column count: %d\n", count );

    for ( i = 0; i < count; i++ ) {
        resultset_get_pgtype( i, &type );
        resultset_get_int32( i, &value );
        printf( "value = %d\n", value );
    }

    printf( "tester done.\n" );

    return 0;
}
