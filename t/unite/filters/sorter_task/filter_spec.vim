describe 'the sorter_task filter'
  describe 'getting the definition'
    after
      call unite#taskwarrior#config#reset()
    end

    it 'can get the given definition'
      let context = {'custom_sorting': 'due+'}
      let def = unite#filters#sorter_task#get_sorting_definition(context)
      Expect def == 'due+'
    end

    it 'can get the definition by given name'
      call unite#taskwarrior#config#set('sort_orders', {'L': 'due+', 'P': 'due+,project-'})
      let context = {'custom_sorting': 'P'}
      let def = unite#filters#sorter_task#get_sorting_definition(context)
      Expect def == 'due+,project-'
    end

    it 'defaults to the default filter'
      call unite#taskwarrior#config#set('default_ordering', 'project+')
      let def = unite#filters#sorter_task#get_sorting_definition({})
      Expect def == 'project+'
    end
  end

  " describe 'sorting tasks'
  " end
end
