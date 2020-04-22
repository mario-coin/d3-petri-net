$('.add-row').on 'click', (e) ->
  e.preventDefault()
  table_body = $(e.target).data().table
  if table_body
    add_row(table_body)

add_row = (table_body_element) ->
# Get some variables for the tbody and the row to clone.
  $tbody = $('#' + table_body_element)
  $rows = $($tbody.children('tr'))
  $cloner = $rows.eq(0)
  count = $rows.length

  # Clone the row and get an array of the inputs.
  $new_row = $cloner.clone()
  inputs = $new_row.find('.dyn-input')

  # Change the name and id for each input.
  $.each(inputs, (i, v) ->
    $input = $(v)

    # Find the label for input and adjust it.
    $label = $new_row.find("label[for='#{$input.attr('id')}']")
    $label.attr( {'for': $input.attr('id').replace(/\[.*\]/, "[#{count + 1}]")} )

    $input.attr({
      'name': $input.attr('name').replace(/\[.*\]/, "[#{count + 1}]"),
      'id': $input.attr('id').replace(/\[.*\]/, "[#{count + 1}]")
    })

    # Remove values and checks.
    $input.val('')
    checked = $input.prop('checked')
    if checked
      $input.prop('checked', false)
  )

  # Add the new row to the tbody.
  $tbody.append($new_row)