describe 'Some utilities'
  describe 'flattening a list'
    it 'can flatten a list'
      Expect unite#taskwarrior#flatten([[1, [2], 3]]) == [1, 2, 3]
    end

    it 'returns empty list given an empty list'
      Expect unite#taskwarrior#flatten([]) == []
    end

    it 'ignores empty parts when flattening'
      Expect unite#taskwarrior#flatten([1, 2, [[]], 3]) == [1, 2, 3]
    end
  end

  describe 'trimming whitespace'
    it 'can strip out whitespace'
      Expect unite#taskwarrior#trim('    a    ') == 'a'
    end

    it 'works fine if the string is empty'
      Expect unite#taskwarrior#trim('') == ''
    end
  end
end
