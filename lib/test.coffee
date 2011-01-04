passed = 0
failed = 0

testSet = (name, func) ->
  puts "Test Set: '#{name}'"
  func()

testStats = () ->
  puts "Passed = #{passed}, Failed = #{failed}"

equals = (v1, v2, text = 'unknown') ->
  if v1 != v2
    puts "  FAILED: expected '#{v2}', got '#{v1}' for test '#{text}'"
    failed += 1
  else
    passed += 1
#    puts "  OK: #{text}"

ok = (bool, text = 'unknown') ->
  if !bool
    puts "  FAILED: #{text}"
    failed += 1
  else
    passed += 1
#    puts "  OK: #{text}"
