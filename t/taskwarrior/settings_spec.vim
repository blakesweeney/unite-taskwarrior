describe 'settings functions'
  describe 'getting a setting'
    it 'can get a setting'
      let ans = {'name': 'verbose', 'value': 'no'}
      Expect unite#taskwarrior#settings#get('verbose') == ans
    end

    it 'gives empty for unknown value'
      Expect unite#taskwarrior#settings#get('bob') == {}
    end
  end

  describe 'setting a value'
    it 'can set a value'
      SKIP 'NYI'
    end

    it 'can delete a setting'
      SKIP 'NYI'
    end

    it 'can set a value to blank'
      SKIP 'NYI'
    end
  end
end
