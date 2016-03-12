#ifndef DEADPOTATO_ERR_H
enum ErrorCodes {
	OK,
	UNEXPECTED_EOF,
	UNCAUGHT
};

struct ParseError {
	char *message;
	enum ErrorCodes code;
};
struct ParseError *init_parse_error(char *err_msg);
void destroy_parse_error(struct ParseError *err);
#define DEADPOTATO_ERR_H
#endif
