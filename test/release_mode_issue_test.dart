import 'package:jsonlogic/jsonlogic.dart';
import 'package:test/test.dart';

void main() {
  test('some operator works with nested fields', () {
    final rule = {
      'some': [
        {'var': 'membership.custom_data.fields'},
        {
          'and': [
            {
              '==': [
                {'var': 'custom_type.id'},
                '20cac88f-eb32-4b20-ab24-142d0f4cf1b9'
              ]
            },
            {
              '==': [
                {'var': 'value'},
                't1'
              ]
            }
          ]
        }
      ]
    };

    final data = {
      'membership': {
        'custom_data': {
          'fields': [
            {
              'id': '6eda1c8b-cc16-452f-b5de-e15164f42382',
              'custom_type': {'id': '6eda1c8b-cc16-452f-b5de-e15164f42382'},
              'value': '["test2"]'
            },
            {
              'id': '6eda1c8b-cc16-452f-b5de-e15164f42382',
              'custom_type': {'id': '6eda1c8b-cc16-452f-b5de-e15164f42382'},
              'value': '["test1"]'
            },
            {
              'id': '20cac88f-eb32-4b20-ab24-142d0f4cf1b9',
              'custom_type': {'id': '20cac88f-eb32-4b20-ab24-142d0f4cf1b9'},
              'value': 't1'
            }
          ]
        }
      }
    };

    final jl = Jsonlogic();
    final result = jl.apply(rule, data);
    expect(result, isTrue);
  });
}
