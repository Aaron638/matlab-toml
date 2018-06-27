classdef TestTomlEncode < matlab.unittest.TestCase

  methods (Test)

    function testValidation(testCase)
      matl_obj = { ...
          1 ...
        , {'a', 'b', 'c'} ...
        , struct('abc', {'a', 'b', 'c'}) ...
        , struct('abc', scatteredInterpolant()) ...
                 };
      err_type = { ...
          'toml:InvalidBaseType' ...
        , 'toml:InvalidBaseType' ...
        , 'toml:NonScalarStruct' ...
        , 'toml:NonEncodableType' ...
                 };

      err_msg = { ...
          'Did not reject a non-struct base type.' ...
        , 'Did not reject a non-struct base type.' ...
        , 'Did not reject a multidimensional base table.' ...
        , 'Did not reject a type that cannot be serialized.' ...
                };

      for indx = 1:numel(matl_obj)
        testCase.verifyError(@() toml.encode(matl_obj{indx}), ...
                             err_type{indx}, err_msg{indx})
      end
    end

    function testEdgeCases(testCase)
      test_strcts = { ...
          struct('key', ['line1'; 'line2'; 'line3']) ...
                    };

      translations = { ...
          struct('key', {{'line1', 'line2', 'line3'}}) ...
                     };

      case_names = { ...
                   '2D char array' ...
                   };

      for indx = 1:numel(test_strcts)
        testCase.verifyEqual(toml.decode(toml.encode(test_strcts{indx})), ...
          translations{indx}, ...
          ['Did not handle edge case appropriately: ', case_names{indx}, '.'])
      end
    end

    function testRoundTrip(testCase)
      test_strct = struct( ...
          'field1', 'abcdefg' ...
        , 'field2', 100 ...
        , 'field3', true ...
        , 'field4', [1, 2, 3] ...
        , 'field5', {{'a', 'b', 'c'}} ...
        , 'field6', struct('sub1field1', 'wxyz') ...
        , 'field7', struct('sub2field1', struct('subsub1field1', 'lmnop')) ...
        , 'field8', datetime('now', 'TimeZone', 'UTC') ...
        , 'field9', {{struct('a', 1), struct('b', 2), struct('c', 3)}} ...
          );

      testCase.verifyEqual(toml.decode(toml.encode(test_strct)), test_strct, ...
        'Did not perform a round-trip serialize/deserialize correctly.')
    end

  end

end