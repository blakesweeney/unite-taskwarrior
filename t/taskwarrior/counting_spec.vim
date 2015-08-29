describe 'counting'
  before
    call vimproc#system('rake reset')
  end

  it 'can get the count given a query string'
    Expect unite#taskwarrior#count('project.is:proj-1') == 2
  end

  it 'can get the count given a query list'
    Expect unite#taskwarrior#count(['project.is:proj-1', 'tag.is:a-tag']) == 1
  end
end
