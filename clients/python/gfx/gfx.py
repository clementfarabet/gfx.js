import os.path

js = {}

js['static'] = os.path.join(os.path.expanduser('~'),'.gfx.js/static/data/')
js['template'] = os.path.join(os.path.expanduser('~'),'.gfx.js/templates/')

if not os.path.exists(js['static']):
    os.makedirs(js['static'])

js['templates'] = {}

# Read templates from their saved location
for file in os.listdir(js['template']):
    if file.endswith('.html'):
        f = open(os.path.join(js['template'],file),'rb')
        template = f.read()
        js['templates'][file[:-5]] = template
        
def log(id):
    print '[gfx.js] rendering cell <%s>'%id

def getDOMName(filename):
    ''' Converts a filename into a unique dom name. '''
    import hashlib
    return 'dom_' + hashlib.md5(filename).hexdigest() + '.png'

def render(filepath, width='', refresh=False, legend=''):
    ''' 
        Render an image in the browser.
        filepath: path to that image
        width: width to render the image
        refresh: refresh image code
        legend: name the image
    '''

    # Ex. filepath = /user/pictures/giraffe.png
    image_path_no_extension = os.path.splitext(filepath)[0] # Eg. /user/pictures/giraffe
    image_file = os.path.basename(filepath) # Eg. giraffe.png
    image_dir = os.path.dirname(filepath) # Eg. /user/pictures

    dom_file = getDOMName(image_file) # giraffe.png ==> dom_random-string.png
    try: # Hardlink the image to the dom_file
        os.link(filepath, os.path.join(image_dir,dom_file))
    except OSError:
        pass
    image_path_no_extension = os.path.splitext(os.path.join(image_dir,dom_file))[0]

    html = js['templates']['image']
    html = html.replace('${width}',str(width))
    html = html.replace('${filename}',dom_file)
    html = html.replace('${id}',image_path_no_extension)
    html = html.replace('${legend}',legend)
    html = html.replace('${refresh}', str(refresh))

    f = open(image_path_no_extension + '.html','w')
    f.write(html)
    f.close()

    log(image_path_no_extension)
    return image_path_no_extension

def create_config(static_dir=os.path.join(os.path.expanduser('~'),'.gfx.js/static/data'),
                  shell='bash', port=8000):
    ''' 
        Create the config file for Node JS to read. The most important part is
        is to specify the directory to monitor for new images.
    '''
    jdict = {
        'shell':shell,
        'port':port,
        'static':static_dir,
        'https': {
            'key': os.path.join(os.path.expanduser('~'),'.gfx.js/defaultcert/ca.key'),
            'cert': os.path.join(os.path.expanduser('~'),'.gfx.js/defaultcert/ca.crt')
            }
        }
    outname = os.path.join(os.path.expanduser('~'),'.gfx.js/config.json')
    import json
    with open(outname,'w') as outfile:
        json.dump(jdict, outfile)

def startserver(monitor_dir=os.path.join(os.path.expanduser('~'),'.gfx.js/static/data'),
                port=8000):
    ''' Starts the gfx server on the specified port monitoring the specified directory '''
    import urllib2
    
    status = None
    try:
        status = urllib2.urlopen('https://localhost:' + str(port))
    except urllib2.URLError:
        pass
    
    if status is None:
        # Create server configuration file
        create_config(monitor_dir)
        # Start the server
        server = os.path.join(os.path.expanduser('~'),'.gfx.js/server.js')
        log = os.path.join(os.path.expanduser('~'),'.gfx.js/server.log')
        cmd = 'node ' + server + ' --port ' + str(port) + ' > ' + log + ' &'
        os.system(cmd)
        print '[gfx.js] server started on port %s, monitoring directory %s Graphics will be rendered into https://localhost:%s'%(str(port),monitor_dir,str(port))
    else:
        print '[gfx.js] server already running on port ' + str(port) + ', graphics will be rendered into https://localhost:' + str(port)

def killserver(port=8000):
    ''' Kill the server running at the specified port. '''
    import subprocess

    ps = subprocess.Popen('ps -ef | grep -v grep | grep \"server.js --port '+str(port) + '\"', shell=True, stdout=subprocess.PIPE)
    output = ps.stdout.read()
    ps.stdout.close()
    ps.wait()

    if not output:
        print '[gfx.js] sever not found on port ' + str(port)
    else:
        pid = int(output.split()[1])
        os.kill(pid, 2)
        print '[gfx.js] server stopped on port ' + str(port)

def show(port=8000):
    ''' Load the webpage associated with the server. '''
    import sys, time
    platform = sys.platform
    if 'linux' in platform:
        time.sleep(.1)
        os.system('xdg-open https://localhost:'+str(port))
    elif 'darwin' in platform:
        time.sleep(.1)
        os.system('open https://localhost:'+str(port))
    else:
        print('[gfx.js] show() is not supported on ' + platform + ' - navigate to https://localhost:PORT by hand')
