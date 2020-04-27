# -----------------------------------
# dados iniciais
# -----------------------------------
petri1 =
  places: [
    # lugares
    { name: ">", count: 1 }
    { name: "l2", count: 2 }
    { name: "l3", count: 0 }
    { name: "l4", count: 1 }
    { name: "^", count: 0 }
  ]
  transitions: [
    # transições
    { name: "t2" }
    { name: "!" }
  ]
  # arcos
  edges: [
    { source: ">", target: "!" }
    { source: "!", target: "l3" }
    { source: "!", target: "l2" }
    { source: "l2", target: "!" }
    { source: "l3", target: "t2" }
    { source: "l4", target: "t2" }
    { source: "t2", target: "^" }
  ];
petri2 =
  places: [
    # lugares
    { name: ">", count: 2 }
    { name: "l2", count: 0 }
    { name: "l3", count: 2 }
    { name: "l4", count: 0 }
    { name: "l5", count: 5 }
    { name: "l6", count: 0 }
    { name: "l7", count: 0 }
    { name: "^", count: 0 }
  ]
  transitions: [
    # transições
    { name: "t2" }
    { name: "t3" }
    { name: "t4" }
    { name: "!" }
  ]
  # arcos
  edges: [
    { source: ">", target: "!" }
    { source: "!", target: "l2" }
    { source: "l2", target: "t2" }
    { source: "t2", target: "l4" }
    { source: "l4", target: "t3" }
    { source: "t3", target: "l3" }
    { source: "l3", target: "t2" }
    { source: "t3", target: "l7" }
    { source: "t3", target: "l6" }
    { source: "l7", target: "t4" }
    { source: "l6", target: "t4" }
    { source: "t4", target: "l5" }
    { source: "l5", target: "t2" }
    { source: "t4", target: "^" }
  ];
petri3 =
  places: [
    # lugares
    { name: ">", count: 1 }
    { name: "l2", count: 0 }
    { name: "l3", count: 0 }
    { name: "l4", count: 0 }
    { name: "^", count: 0 }
  ]
  transitions: [
    # transições
    { name: "t2" }
    { name: "t3" }
    { name: "!" }
  ]
  # arcos
  edges: [
    { source: ">", target: "!" }
    { source: "!", target: "l2" }
    { source: "l2", target: "t2" }
    { source: "l2", target: "t3" }

    { source: "t2", target: "l3" }
    { source: "t3", target: "l4" }

    { source: "l3", target: "^" }
    { source: "l4", target: "^" }
  ];

# -----------------------------------
# gerar dados na tabela
# -----------------------------------
$tbody_places = $('#pda-places')
$tbody_transition = $('#pda-transition')
$tbody_arc = $('#pda-arc')

$('#read-ex1').on 'click', (e) ->
  e.preventDefault()
  read(petri1)

$('#read-ex2').on 'click', (e) ->
  e.preventDefault()
  read(petri2)

$('#read-ex3').on 'click', (e) ->
  e.preventDefault()
  read(petri3)

read = (petri) ->
  # escrever na tabela lugares
  petri.places.map (j, i) ->
    $tbody_places.append(['<tr>
                              <td>
                                  <input class="dyn-input" type="text" id="name" name="name" value="' + j.name + '" />
                              </td>
                              <td>
                                  <input class="dyn-input" type="text" id="count" name="count" value="' + j.count + '" />
                              </td>
                              <td>
                                  <button class="button tiny secondary delete-row">x</button>
                              </td>
                          </tr>'])

  # escrever na tabela transições
  petri.transitions.map (j, i) ->
    $tbody_transition.append(['<tr>
                                  <td>
                                      <input class="dyn-input" type="text" id="name" name="name" value="' + j.name + '" />
                                  </td>
                                  <td>
                                      <button class="button tiny secondary delete-row">x</button>
                                  </td>
                              </tr>'])

  # escrever na tabela arcos
  petri.edges.map (j, i) ->
    # console.log(i, j)
    $tbody_arc.append(['<tr>
                            <td>
                                <input class="dyn-input" type="text" id="source" name="source" value="' + j.source + '" />
                            </td>
                            <td>
                                <input class="dyn-input" type="text" id="target" name="target" value="' + j.target + '" />
                            </td>
                            <td>
                                <button class="button tiny secondary delete-row">x</button>
                            </td>
                        </tr>'])

  $('.add-row').attr('disabled', false);
  $('.read-ex').attr('disabled', true);
  $('#build').attr('disabled', false);

  build_delete_row()

# -----------------------------------
# build petri net
# -----------------------------------
$('#build').on 'click', (e) ->
  e.preventDefault()
  build()

build = () ->
  $d3 = d3
  $jq = $ # jquery

  $('.add-row').attr('disabled', true);
  $('.read-ex').attr('disabled', true);
  $('#build').attr('disabled', true);

  width = $jq("#rhs").width()
  height = $jq("#rhs").height()
  color = d3.scale.category20()

  force = d3.layout.force()
    .charge( -250 )
    .linkDistance( 45 )
    .size([ width, height ])

  json =
    nodes: []
    edges: [];

  # mapear lugares
  $($tbody_places.children('tr')).map (j, i) ->
    json.nodes.push { id: j, name: $(i).find('#name').val(), group: 0, count: +$(i).find('#count').val() }
  length = json.nodes.length
  # mapear transições
  $($tbody_transition.children('tr')).map (j, i) ->
    json.nodes.push { id: length + j, name: $(i).find('#name').val(), group: 1 }
  # mapear arcos
  $($tbody_arc.children('tr')).map (j, i) ->
    s = (json.nodes.filter (x) -> $(i).find('#source').val() == x.name)[0].id
    t = (json.nodes.filter (x) -> $(i).find('#target').val() == x.name)[0].id
    json.edges.push { source: s, target: t }

  # rodar rede petri
  force
    .nodes( json.nodes )
    .links( json.edges )
    .start()

  AND = (a, b) -> a and b
  all = (xs) -> xs.length and xs.reduce( AND, true )

  incoming = (n) -> e for e in json.edges when e.target is n
  outgoing = (n) -> e for e in json.edges when e.source is n
  active = (n) -> all ( e.source.count > 0 for e in incoming n  )

  holds = -> n for n in json.nodes when n.group is 0
  tasks = -> n for n in json.nodes when n.group is 1

  radius = 15

  svg = d3.select("svg")
  links = svg.selectAll( "line.link" )
      .data( json.edges )
      .enter().append( "line" )
      .attr( "class", "link" )
      .style( "stroke", "#000" )
      .style( "stroke-width", 2 );

  circs = svg.selectAll("circle.node")
      .data( holds )
      .enter().append( "circle" )
      .attr( "class", "node" )
      .attr( "r", radius )
      .style( "fill", (d)->
          if d.name is '>' then 'lime'
          else if d.name is '^' then 'red'
          else 'white' )
      .style( "stroke", '#000' )
      .style( "stroke-width", '2' )
      .call( force.drag )

  dead_color = '#333'
  live_color = '#666'
  click_color = '#999'

  box_color = (d, i) -> if active d then live_color else dead_color

  texts = svg.selectAll("text")
    .data( holds )
    .enter().append( "text" )
    .call( force.drag )
    .text( (d)-> if d.count is 0 then '' else d.count )

  rects = svg.selectAll("rect.node")
    .data( tasks )
    .enter().append( "rect" )
      .attr( "class", "node" )
      .attr( "width", radius * 2 )
      .attr( "height", radius * 2 )
      .style( "stroke", '#000' )
      .style( "stroke-width", '2' )
      .style( "fill", box_color )
      .call( force.drag )
      .on 'click', (g, j)->
          if (active g) then do =>
              for e in incoming g
                e.source.count -= 1
              for e in outgoing g
                e.target.count += 1
              $d3.select( this )
                .style( 'fill', click_color )
              rects.transition()
                .style( 'fill', box_color )
              texts.transition()
                .text( (d)-> if d.count is 0 then '' else d.count )


  node = svg.selectAll(".node")
  node.append( "title" )
    .text( (d) -> d.name )

  force.on "tick", ->
    texts
      .attr( "x", (d) -> d.x - 5 )
      .attr( "y", (d) -> d.y + 5 )
    links
      .attr( "x1", (d) -> d.source.x )
      .attr( "y1", (d) -> d.source.y )
      .attr( "x2", (d) -> d.target.x )
      .attr( "y2", (d) -> d.target.y )
    circs
      .attr( "cx", (d) -> d.x )
      .attr( "cy", (d) -> d.y );
    rects
      .attr( "x", (d) -> d.x - radius )
      .attr( "y", (d) -> d.y - radius )

# -----------------------------------
# table events
# -----------------------------------
$('.add-row').on 'click', (e) ->
  e.preventDefault()
  table_body = $(e.target).data().table
  if table_body
    add_row(table_body)
    build_delete_row()

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

# delete table row
build_delete_row = () ->
  $('.delete-row').on 'click', (e) ->
    e.preventDefault()
    $(e.target).closest('tr').remove()