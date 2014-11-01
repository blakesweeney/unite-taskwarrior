describe 'basic unite#taskwarrior actions'
  before
    call vimproc#system("./run setup")
  end

  after
    call vimproc#system("./run setup")
  end

  it 'can list all tasks'
   let tasks = unite#taskwarrior#select([])
   Expect 4 == len(tasks)
 end

 it 'can list all projects'
    let projects = unite#taskwarrior#projects#select([])
    Expect 2 == len(projects)
  end

  it 'can list all tags'
    let projects = unite#taskwarrior#tags#select([])
    Expect 2 == len(projects)
  end

  it 'can get tasks by projects'
    let tasks = unite#taskwarrior#select(["proj:proj-1"])
    Expect 2 == len(tasks)
  end

  it 'can get tasks by tags'
    let tasks = unite#taskwarrior#select(["tag:a-tag"])
    Expect 2 == len(tasks)
  end

  it 'can get tasks by several filters'
    let tasks = unite#taskwarrior#select(["tag:a-tag", "proj:proj-1"])
    Expect 1 == len(tasks)
  end

  it 'return empty list for no tasks'
    let tasks = unite#taskwarrior#select(["uuid:steve"])
    Expect 0 == len(tasks)
  end

  it 'can get the project of a task'
    let task = unite#taskwarrior#select(["uuid:942f9c02-855b-4143-8c19-1bc64c963b33"])
    Expect 1 == len(task)
    Expect "proj-1" == task[0].project
  end

  it 'can get the tags of a task'
    let task = unite#taskwarrior#select(["uuid:ac5ca2e6-869d-4af7-964a-e24e8b49e60c"])
    Expect 1 == len(task)
    Expect ["boring"] == task[0].tags
  end

  it 'can run an task command'
    let result = unite#taskwarrior#call('', 'report')
    Expect 0 <= len(result)
  end

  it 'can trim a string'
    let result = unite#taskwarrior#trim("  Add some useful task proj:other  ")
    let ans = "Add some useful task proj:other"
    Expect ans == result
  end

  it 'get a task status'
    let task = unite#taskwarrior#select(["uuid:ac5ca2e6-869d-4af7-964a-e24e8b49e60c"])
    Expect 1 == len(task)
    Expect "pending" == task[0].status
  end
end
