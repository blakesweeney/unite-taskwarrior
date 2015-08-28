describe 'Calling taskwarrior'
  before
    call unite#taskwarrior#config('command', './run')
    call vimproc#system("./run setup")
  end

  describe 'with command line arguments'
    it 'uses the configured command and returns the raw output'
      Expect unite#taskwarrior#call('count') == "4\n"
    end

    it 'will take a list of arguments to use'
      Expect unite#taskwarrior#call([1, 'count']) == "1\n"
    end

    it 'can deal with nested arguments'
      Expect unite#taskwarrior#call([[1], 'count']) == "1\n"
    end

    it 'will take a command line string to use'
      Expect unite#taskwarrior#call('1,2 count') == "2\n"
    end
  end

  describe 'using a task object'
    it 'uses the uuid as a filter'
      let task = {'uuid': '942f9c02-855b-4143-8c19-1bc64c963b33', 'status': 'pending'}
      Expect unite#taskwarrior#run(task, 'count') == "1\n"
    end
    
    it 'will accept several arguments to list'
      let task = {'uuid': '942f9c02-855b-4143-8c19-1bc64c963b33', 'status': 'pending'}
      Expect unite#taskwarrior#run(task, 'ids', 2) == "1-2\n"
    end

    it 'will accept a list as the command'
      let task = {'uuid': '942f9c02-855b-4143-8c19-1bc64c963b33', 'status': 'pending'}
      Expect unite#taskwarrior#run(task, ['ids', 2]) == "1-2\n"
    end
  end
end
