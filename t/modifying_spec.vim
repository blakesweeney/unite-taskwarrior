describe 'Modifying the tasks'
  before
    call vimproc#system("./run setup")
  end

  after
    call vimproc#system("./run setup")
  end

  it 'can add and delete a task'
    let title = "This is a new task"
    call unite#taskwarrior#new(title)

    let tasks = unite#taskwarrior#select([])
    Expect 5 == len(tasks)

    let task = unite#taskwarrior#select(["desc:'" . title . "'"])
    Expect 1 == len(task)
  end

  it 'can add an annotation to a task'
    let annotation = "Something informative"
    let task = unite#taskwarrior#select(["uuid:ac5ca2e6-869d-4af7-964a-e24e8b49e60c"])
    Expect 1 == len(task)

    call unite#taskwarrior#annotate(task[0], annotation)
    let task = unite#taskwarrior#select(["uuid:ac5ca2e6-869d-4af7-964a-e24e8b49e60c"])
    Expect 1 == len(task)
    Expect annotation == task[0].annotations[0].description
  end

  it 'can mark a task as started or stopped'
    let task = unite#taskwarrior#select(["uuid:ac5ca2e6-869d-4af7-964a-e24e8b49e60c"])
    Expect 1 == len(task)
    call unite#taskwarrior#start(task[0])

    let task = unite#taskwarrior#select(["uuid:ac5ca2e6-869d-4af7-964a-e24e8b49e60c"])
    Expect 1 == len(task)
    Expect 1 == task[0].started
    Expect 0 != task[0].stop_time

    call unite#taskwarrior#stop(task[0])
    let task = unite#taskwarrior#select(["uuid:ac5ca2e6-869d-4af7-964a-e24e8b49e60c"])
    Expect 1 == len(task)
    Expect 1 == task[0].stopped
    Expect 0 != task[0].stop_time
  end

  it 'can modify the title of a task'
    let title = "here is a new title"
    let task = unite#taskwarrior#select(["uuid:ac5ca2e6-869d-4af7-964a-e24e8b49e60c"])
    Expect 1 == len(task)
    let task[0].description = title
    call unite#taskwarrior#rename(task[0])

    let task = unite#taskwarrior#select(["uuid:ac5ca2e6-869d-4af7-964a-e24e8b49e60c"])
    Expect 1 == len(task)
    Expect title == task[0].description
  end

  it 'can modify the project of a task'
    let project = "a-new-project"
    let task = unite#taskwarrior#select(["uuid:ac5ca2e6-869d-4af7-964a-e24e8b49e60c"])
    Expect 1 == len(task)
    call unite#taskwarrior#project(task[0], project)

    let task = unite#taskwarrior#select(["uuid:ac5ca2e6-869d-4af7-964a-e24e8b49e60c"])
    Expect 1 == len(task)
    Expect project == task[0].project
  end

  it 'can do call modify on a task'
    let task = unite#taskwarrior#select(["uuid:942f9c02-855b-4143-8c19-1bc64c963b33"])
    Expect 1 == len(task)

    call unite#taskwarrior#modify(task[0], "+thing")
    let task = unite#taskwarrior#select(["uuid:942f9c02-855b-4143-8c19-1bc64c963b33"])
    Expect 1 == len(task)
    Expect ["thing"] == task[0].tags
  end
end
