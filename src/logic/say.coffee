#
#  Instruct the current character to say some words to others in the same room
#
#  words - words to speak {String}
#
module.exports = (conn, words) =>
  conn.character.speak words
  "You say #{words}"
