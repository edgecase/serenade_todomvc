class Application extends Serenade.Model
  @hasMany 'todos', as: (-> Todo), serialize: true
  @localStorage = true

  @property 'doneTodos',
    get: -> @get('todos').select((item) -> item.get('done'))
    dependsOn: ['todos', 'todos.done']
  @property 'incompleteTodos',
    get: -> @get('todos').select((item) -> not item.get('done'))
    dependsOn: ['todos', 'todos.done']
  @property 'completedCount',
    get: -> @get('doneTodos').length
    format: (val) -> val or "0"
    dependsOn: 'doneTodos'
  @property 'incompleteCount',
    get: -> @get('incompleteTodos').length
    format: (val) -> val or "0"
    dependsOn: 'incompleteTodos'
  @property 'allCompleted',
    get: -> @get('incompleteCount') <= 0
    dependsOn: 'incompleteCount'

  setTodoDone: (done) ->
    @get('todos').forEach (todo) -> todo.set('done', done)

class Todo extends Serenade.Model
  @property 'done', serialize: true
  @property 'status', dependsOn: 'done', get: -> if @get('done') then 'done' else 'active'
  @property 'title', serialize: true

  toggleDone: -> @set('done', !@get('done'))

class ApplicationController
  setTodoDone: ->
    if @model.get('allCompleted')
      @model.setTodoDone(false)
    else
      @model.setTodoDone(true)
  clear: ->
    @model.set('todos', @model.get('incompleteTodos'))
  setTitle: (event) ->
    @title = event.target.value
  addNew: ->
    @model.get('todos').push(title: @title) if @title

class TodoController
  toggleDone: -> @model.toggleDone()

Serenade.registerController('app', ApplicationController)
Serenade.registerController('todo', TodoController)

window.onload = ->

  # boring boilerplate to grab template from html file
  for script in document.getElementsByTagName('script')
    if script.getAttribute('type') is 'text/x-serenade'
      Serenade.registerView script.getAttribute('id'), script.innerText.replace(/^\s*/, '')

  # render and insert
  element = Serenade.render('app', Application.find(1))
  document.getElementById('todoapp').appendChild(element)
