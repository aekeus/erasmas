#
#  Display contents of help
#
#    TODO: make this more helpful
#
module.exports = (conn) =>
  @dispatcher.formattedCommands().join utils.eol
