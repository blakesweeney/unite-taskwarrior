describe 'Creating a filter from source arguments'
  before
    call vimproc#system('rake reset')
  end

  it 'will process things with + to tags'
    let obj = unite#taskwarrior#filters#from_source(['+a', 'b', '+c'], {})
    Expect obj._tags == ['+a', '+c']
  end

  it 'will process @ into context'
    let obj = unite#taskwarrior#filters#from_source(['@c1'], {})
    Expect obj._context == '@c1'
  end

  it 'will process other things to projects'
    let obj = unite#taskwarrior#filters#from_source(['+a', 'b', '+c'], {})
    Expect obj._projects == ['b']
  end

  it 'will use the custom filter and ignore default'
    let obj = unite#taskwarrior#filters#from_source([], {'custom_filter': 'another'})
    Expect obj._raw == ['another']
  end

  it 'will ignore default filter if requested'
    let obj = unite#taskwarrior#filters#from_source([], {'custom_ignore_filter': 0})
    Expect obj._raw == []
  end
end
