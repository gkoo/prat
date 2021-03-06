class BooleanPreferenceView extends Backbone.View
  events:
    "change input": "setValue"

  tagName: "label"

  initialize: (options) ->
    @value = options.value ? options.default

  setValue: =>
    @value = @$el.find("input").is(":checked")
    patchBody = {}
    patchBody[@options.name] = @value
    $.ajax
      type: "PATCH"
      url: "/api/user/preferences"
      data: JSON.stringify(patchBody)
      contentType: "application/json"

    @trigger("change", @options.name, @value)

  render: ->
    template = $("#boolean-preference-template").html()
    @$el.html(Util.mustache(template, description: @options.description))
        .find("input").attr("checked", @value)
    @


class window.Preferences extends Backbone.Events
  @prefs:
    "alert-sounds":
      default: true
      description: "Play an alert sound when you are mentioned and the chat window is not focused."
    "webkit-notifications":
      default: false
      description: "Show a notification when a new message is received."
    "swap-enter":
      default: false
      description: "In the input box, <code>enter</code> inserts a newline and <code>shift</code>+<code>enter</code> sends a message."
    "hide-images":
      default: false
      description: "Auto-hide all images/YouTube videos in new messages."
    "show-offline":
      default: true
      description: "Show offline users in the sidebar"

  @get: (name) -> @prefs[name].view.value

  @init: (initialPrefs) ->
    for name, pref of @prefs
      @prefs[name].view = view = new BooleanPreferenceView
        value: initialPrefs[name]
        description: pref.description
        default: pref.default
        name: name
      $("#preferences .modal-body").append(view.render().el)
      view.on("change", @handleChange)

    $("#settings-button").on "click", @show

  @show: ->
    $("#preferences").modal("toggle")

  @handleChange: (name, value) =>
    if name is "webkit-notifications" and value
      webkitNotifications?.requestPermission()

    @trigger("change:#{name}", value)
