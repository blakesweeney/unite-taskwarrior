describe 'the configuration wrapper'
  before
    call unite#taskwarrior#config#reset()
  end

  it 'can set a value'
    call unite#taskwarrior#config('command', 'other')
    Expect unite#taskwarrior#config#get('command') == 'other'
  end

  it 'can get a value'
    call unite#taskwarrior#config('command', 'a')
    Expect unite#taskwarrior#config('command') == 'a'
  end

  it 'will get the current'
    let current = unite#taskwarrior#config()
    let ans = unite#taskwarrior#config#current()
    Expect current == ans
  end
end
