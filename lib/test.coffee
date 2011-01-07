passed = 0
failed = 0

testSets = {}
testSet = (name, func) ->
  testSets[name] = func

testStats = () ->
  puts "Passed = #{passed}, Failed = #{failed}"

runTests = (test) ->
  unless test?
    for name, func of testSets
      puts "Test Set: '#{name}'"
      func()
  else
    puts "Test Set: '#{test}'"
    testSets[test]()

equals = (v1, v2, text = 'unknown') ->
  if v1 != v2
    puts "  FAILED: expected '#{v2}', got '#{v1}' for test '#{text}'"
    failed += 1
  else
    passed += 1
    puts "  OK: #{text}"

eq = equals

ok = (bool, text = 'unknown') ->
  if !bool
    puts "  FAILED: #{text}"
    failed += 1
  else
    passed += 1
    puts "  OK: #{text}"
