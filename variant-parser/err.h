#ifndef DEADPOTATO_ERR_H
struct ParseError {
	char *message;
};
struct ParseError *init_parse_error(char *err_msg);
void destroy_parse_error(struct ParseError *err);
#define DEADPOTATO_ERR_H
#endif
