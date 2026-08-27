# SPDX-License-Identifier: GPL-2.0
#
# Sphinx has deprecated its older logging interface, but the replacement
# only goes back to 1.6.  So here's a wrapper layer to keep around for
# as long as we support 1.4.
#
import sphinx

if sphinx.__version__[:3] >= '1.6':
    UseLogging = True
    from sphinx.util import logging
    logger = logging.getLogger('kerneldoc')
else:
    UseLogging = False

def warn(app, message=None):
    if message is None:
        message = app
    if UseLogging:
        logger.warning(message)
    elif app is not None and hasattr(app, 'warn'):
        app.warn(message)

def verbose(app, message=None):
    if message is None:
        message = app
    if UseLogging:
        logger.verbose(message)
    elif app is not None and hasattr(app, 'verbose'):
        app.verbose(message)


