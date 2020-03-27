#ifndef STUB_CONNECTOR_H_
#define STUB_CONNECTOR_H_

#include <string>
#include <string_view>

#include "ogawayama/stub/error_code.h"
#include "ogawayama/stub/api.h"

class StubConnector {
public:
	static ERROR_CODE get_connection(ogawayama::stub::Connection** connection);
	StubConnector() = delete;

private:
	static StubPtr stub_;
	static ConnectionPtr connection_;

	static ERROR_CODE init();
};

#endif // STUB_CONNECTOR_H_
