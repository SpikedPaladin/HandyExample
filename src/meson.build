project_deps = [
    dependency('gio-2.0', version: '>= 2.50'),
    dependency('gtk+-3.0', version: '>= 3.22'),
    dependency('libhandy-1')
]

project_sources = files(
    'main.vala',
    
    'core/application.vala',
    
    'ui/main-window.vala',
    
    'ui/tabs-window.vala'
)

executable('handy-example',
    project_resources,
    project_sources,
    vala_args: '--target-glib=2.50',
    dependencies: project_deps,
    install: true,
)
