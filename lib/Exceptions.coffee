UserException = ->
UserException::            = Object.create Error
exports.UserException = UserException

VariantParseException = ->
VariantParseException::    = Object.create Error
exports.VariantParseException = VariantParseException

VariantValidateException = ->
VariantValidateException:: = Object.create Error
exports.VariantValidateException = VariantValidateException

S3UploadException = ->
S3UploadException::        = Object.create Error
exports.S3UploadException = S3UploadException

ResolverException = ->
ResolverException::        = Object.create Error
exports.ResolverException = ResolverException

EngineException = ->
EngineException::          = Object.create Error
exports.EngineException = EngineException

GraphQLException = ->
GraphQLException::         = Object.create Error
exports.GraphQLException = GraphQLException
