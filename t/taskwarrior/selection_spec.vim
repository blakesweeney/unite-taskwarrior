describe 'basic unite#taskwarrior actions'
  before
    call vimproc#system("rake reset")
  end

  it 'can list all tasks'
   let tasks = unite#taskwarrior#select([])
   Expect tasks == 4
 end

 it 'can list all projects'
    let projects = unite#taskwarrior#projects#select([])
    Expect projects == [{"name": "proj-1", "count": 2}, {"name": "proj-2", "count": 2}]
  end

  it 'can list all tags'
    let tags = unite#taskwarrior#tags#select([])
    Expect tags == [{"name": "boring", "count": 1}, {"name": "a-tag", "count": 2}]
  end

  it 'can get tasks by projects'
    let tasks = unite#taskwarrior#select(["proj.is:proj-1"])
    Expect len(tasks) == 2
  end

  it 'can get tasks by tags'
    let tasks = unite#taskwarrior#select(["tag.is:a-tag"])
    Expect len(tasks) == 2
  end

  it 'can get tasks by several filters'
    let tasks = unite#taskwarrior#select(["tag.is:a-tag", "proj.is:proj-1"])
    Expect len(tasks) == 1
  end

  it 'return empty list for no tasks'
    let tasks = unite#taskwarrior#select(["steve"])
    Expect len(tasks) == 0
  end

  it 'can get the project of a task'
    let task = unite#taskwarrior#select(["942f9c02-855b-4143-8c19-1bc64c963b33"])
    Expect len(task) == 1
    Expect task[0].project == "proj-1"
  end

  it 'can get the tags of a task'
    let task = unite#taskwarrior#select(["ac5ca2e6-869d-4af7-964a-e24e8b49e60c"])
    Expect len(task) == 1
    Expect task[0].tags == ['boring']
  end

  it 'can run an task command'
    let result = unite#taskwarrior#call('report')
    Expect len(result) >= 0
  end

  it 'can trim a string'
    let result = unite#taskwarrior#trim("  Add some useful task proj:other  ")
    let ans = "Add some useful task proj:other"
    Expect result == ans
  end

  it 'get a task status'
    let task = unite#taskwarrior#select(["ac5ca2e6-869d-4af7-964a-e24e8b49e60c"])
    Expect len(task) == 1
    Expect task[0].status == "pending"
  end
end
