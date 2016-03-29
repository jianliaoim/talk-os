
isTrue = (x) -> x is true

exports.all = (calls, success) ->
  calls = calls.filter (task) -> task?
  if calls.length is 0
    success(calls)
  else
    results = calls.map -> null
    doneList = calls.map -> false
    calls.forEach (call, index) ->
      resolve = (result) ->
        results[index] = result
        doneList[index] = true
        check()
      reject = (error) ->
        results[index] = error
        doneList[index] = true
        check()
      check = ->
        if doneList.every(isTrue)
          success results
      call resolve, reject
      return true
