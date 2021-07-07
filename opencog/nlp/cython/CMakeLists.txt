#
ADD_SUBDIRECTORY (opencog)

# module init
file(MAKE_DIRECTORY opencog)
file(MAKE_DIRECTORY opencog/nlp)
file(COPY opencog/__init__.py DESTINATION opencog/nlp)
