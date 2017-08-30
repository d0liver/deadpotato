exports.UserException            = class UserException extends Error then constructor: ->
exports.VariantParseException    = class VariantParseException extends UserException
exports.VariantValidateException = class VariantValidateException extends UserException
exports.S3UploadException        = class S3UploadException extends UserException
exports.ResolverException        = class ResolverException extends UserException
exports.EngineException          = class EngineException extends UserException
exports.GraphQLException         = class GraphQLException extends UserException
