'use strict'

$.extend $.fn.bootstrapTable.defaults,
    filterPanel: false
    filterPanelForm: undefined
    filterPanelPosition: 'right'
    filterPanelInputPrefix: 'bt-filter-'


$.extend $.fn.bootstrapTable.defaults.icons,
    filterPanelIcon: 'filter'

$.extend $.fn.bootstrapTable.locales,
    formatFilterPanel: ->
        'filtrer'
$.extend $.fn.bootstrapTable.defaults, $.fn.bootstrapTable.locales

BootstrapTable = $.fn.bootstrapTable.Constructor
_init = BootstrapTable.prototype.init
_initToolbar = BootstrapTable.prototype.initToolbar

BootstrapTable.prototype.initToolbar =  ->
    _initToolbar.apply(@, Array.prototype.slice.apply(arguments))

    return if !@options.filterPanel

    html = []

    html.push "<div class=\"columns columns-#{@options.buttonsAlign} btn-group pull-#{@options.buttonsAlign}\" role=\"group\">"
    html.push "<button class=\"btn btn-default #{if @options.iconSize? then 'btn-' + @options.iconSize else ''}\" type=\"button\" name=\"filterPanel\" title=\"#{@options.formatFilterPanel()}\">"
    html.push "<i class=\"#{@options.iconsPrefix} #{@options.iconsPrefix}-#{@options.icons.filterPanelIcon}\"></i>"
    html.push '</button></div>'

    @$toolbar.prepend(html.join(''));
    @$toolbar.find('button[name="filterPanel"]').off('click').on 'click', (evt) =>
        @toggleFilterPanel(evt)

BootstrapTable.prototype.init = ->
    _init.apply(@, Array.prototype.slice.apply(arguments))

    return if !@options.filterPanel

    @.initFilterPanel()

BootstrapTable.prototype.initFilterPanelForm = ->
    if @options.filterPanelForm?
        $form = $(@options.filterPanelForm)
    else
        html = ['<form method="get">']
        for field in @getColumns()
            if field.visible and field.searchable
                html.push '<div class="form-group">'
                html.push "<label>#{field.title}</label>"
                html.push "<input class=\"form-control\" type=\"text\" name=\"#{@options.filterInputPrefix}#{field.field}\" value=\"\"/>"
                html.push '</div>'
        html.push '<button class="btn btn-default pull-right" type="submit">'
        html.push "<i class=\"#{@options.iconsPrefix} #{@options.iconsPrefix}-#{@options.icons.filterPanelIcon}\"></i> Filtrer"
        html.push '</button>'
        html.push('</form>')
        $form = $(html.join(''))
    searchs = {}
    for search in location.search.slice(1).split('&')
        if search.startsWith(@options.filterPanelInputPrefix)
            s = search.split('=')
            $form.find("[name=#{s[0]}]").val(s[1])
    $form


BootstrapTable.prototype.initFilterPanel = ->
    @$container.css
        'display': 'flex'
        'flex-flow': 'row wrap'

    @$filterPanel = $('<div class="fixed-table-panel"></div>').css
        'display': 'None'
    @$filterPanel.append(@initFilterPanelForm())
    @$container.append(@$filterPanel)

    switch @options.filterPanelPosition
        when 'right', 'left'
            if @options.filterPanelPosition is 'left'
                order = 1
                padding = 'padding-right'
            else
                order = 0
                padding = 'padding-left'
            @$toolbar.css
                'flex': '1 0 100%'
            @$filterPanel.css
                'flex': '1 1 30%'
                "#{padding}": '1em'
            @$tableContainer.css
                'flex': '1 1 70%'
                'order': order
        when 'top', 'bottom'
            if @options.filterPanelPosition is 'top'
                order = 1
            else
                order = 0
            @$toolbar.css
                'flex': '1 0 100%'
            @$filterPanel.css
                'flex': '1 1 100%'
            @$tableContainer.css
                'flex': '1 1 100%'
                'order': order

BootstrapTable.prototype.toggleFilterPanel = (evt) ->
    @$toolbar.find('button[name="filterPanel"]').toggleClass('active').blur()
    if @$filterPanel.css('display') is 'none'
        @$filterPanel.css('display', 'block')
    else
        @$filterPanel.css('display', 'None')
    @resetHeader?()