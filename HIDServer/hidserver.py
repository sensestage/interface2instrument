#!/usr/bin/env python

"""     HIDserver 0.3.1
    ixi software - 2011
    www.ixi-software.net
	
	modification September 2007 by Marije Baalman - nescivi - www.nescivi.nl

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
     General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


#######################################
description :
HID OSC server is a SDL based python app that sends out via OSC any HID device (gamepad, joystick)
event generated data.

description of OSC messages sent by the server :
    - adress : /hid
    - value :
    INIT event : [ 'running', joysticklist] # joysticklist is None if no joystick is found 
    QUIT event : [ 'quit' ]
    JOYAXISMOTION event : [ 'axismotion', joystickID, axis, value ]
    JOYBALLMOTION event : [ 'ballmotion',  joystickID, ball, value ]
    JOYHATMOTION event : [ 'hatmotion',  joystickID, hat, value ]
    JOYBUTTONDOWN event : [ 'buttondown', joystickID, button ]
    JOYBUTTONUP event : [ 'buttonup', joystickID, button ]

#########################################
    
"""

from simpleOSC import *
import pygame, os, sys
from pygame.locals import *
import json, logging


logname = "HIDServer.log"



def main( ip = "127.0.0.1", port=57120, rate=12, verbose=0, log=0 ) : 
    error = None

    ip = ip
    port = int(port)
    rate = int(rate)
    verbose = int(verbose)
    log = int(log)

    try :
        f = open('config.json', 'r')
        raw = f.read()
        config = json.loads(raw)
        ip = str(config['ip'])
        port = int(config['port'])
        rate = int(config['rate'])
        verbose = int(config['verbose'])
        log = int(config['log'])
    except IOError :
        error = 'You have not specified a config.json file, it is not compulsory but you might want to use one'
    except ValueError :
        error = 'The format of the config.json file is wrong, skying it...'

    if log :
        logging.basicConfig(filename=logname,
                            filemode='a',
                            format='%(asctime)s,%(msecs)d %(name)s %(levelname)s %(message)s',
                            datefmt='%H:%M:%S',
                            level=logging.INFO)
        logging.info('---- starting up  HID OSC Server ----')
        
    if error :
        logging.warning(error)

    pygame.init()
    
    initOSCClient(ip, port)

    ## Pygame window #################
    screen = pygame.display.set_mode((135, 70), HWSURFACE | DOUBLEBUF)
    pygame.display.set_caption('HID Server')
    pygame.mouse.set_visible(1) #mouse invisible

    background = pygame.Surface(screen.get_size())
    background = background.convert()
    background.fill((255, 255, 255)) #bg color
    screen.blit(background, (0,0))

    font = pygame.font.SysFont("Arial", 14)
    strings = 'HID OSC server', 'ip %s' % ip, 'port %s' % port, 'www.ixi-audio.net'
    locY = 5
    for st in strings :
        txt = font.render(st, 0, (0,0,0))
        screen.blit(txt, (5, locY) )
        locY += 15

    pygame.display.flip()

    #################################

    try: # init joystick
        joy = []
        sticks = []
        
        pygame.joystick.init() # init main joystick device system
        
        for n in range(pygame.joystick.get_count()): #
            stick = pygame.joystick.Joystick(n)
            stick.init() # init instance
            # report joystick charateristics #
            lgstr = '-'*20
            lgstr += '\nEnabled HID device: ' + stick.get_name()
            lgstr += '\nit has the following devices :'
            lgstr += '\n--> buttons : '+ str(stick.get_numbuttons())
            lgstr += '\n--> balls : '+ str(stick.get_numballs())
            lgstr += '\n--> axes : '+ str(stick.get_numaxes())
            lgstr += '\n--> hats : '+ str(stick.get_numhats())
            lgstr += '\n-'*20
            logging.info(lgstr)
            
            joy.append(stick.get_name())
            sticks.append(stick)
    except pygame.error:
        msg = 'no HID device found??'
        logging.warning(msg)
        joy = 'False'

    clock = pygame.time.Clock()

    msg = 'HID server : ready to send HID events via ip %s, port %i, %i times per sec, verbose %i, log %i' % (ip, port, rate, verbose, log)
    logging.info(msg)
    go = 1

##    counter = 0
##    for n in sticks:
    for counter, n in enumerate(sticks) :
        #print '%s' % n.get_name()
        sendOSCMsg("/hid", [ 'running', n.get_name(), counter ])
        sendOSCMsg("/hid", [ counter, 'axes', n.get_numaxes()] )
        sendOSCMsg("/hid", [ counter, 'balls', n.get_numballs()] )
        sendOSCMsg("/hid", [ counter, 'hats', n.get_numhats()] )
        sendOSCMsg("/hid", [ counter, 'buttons', n.get_numbuttons()] )

    while go :
        clock.tick(rate) # fps

        msg = None

        for e in pygame.event.get() :
            if e.type == JOYAXISMOTION: # 7
                msg = [ 'axismotion', e.joy, e.axis, e.value ] # JOYAXISMOTION
            elif e.type == JOYBALLMOTION: # 8
                msg =  [ 'ballmotion', e.joy, e.ball, e.value ] # JOYBALLMOTION
            elif e.type == JOYHATMOTION: # 9
               msg =  [ 'hatmotion', e.joy, e.hat, e.value[0], e.value[1] ] # JOYHATMOTION
            elif e.type == JOYBUTTONDOWN: # 10
                msg = [ 'button', e.joy, e.button, 1 ] # JOYBUTTONDOWN
            elif e.type == JOYBUTTONUP: # 11
                msg = [ 'button', e.joy, e.button, 0 ] # JOYBUTTONUP
                
            elif e.type == KEYUP and e.key == K_ESCAPE :
                go = 0
            elif e.type == QUIT : # escape key or CTRL+Q pressed
                go = 0

##            elif e.type == MOUSEBUTTONDOWN: # 11
##                sendOSCMsg("/hid", [ 'mousedown', e.joy, e.button, pygame.mouse.get_pos() ]) # MOUSEBUTTONDOWN
##             elif e.type == MOUSEBUTTONUP: # 11
##                sendOSCMsg("/hid", [ 'mouseup', e.joy, e.button, pygame.mouse.get_pos() ]) # MOUSEBUTTONUP
##            elif e.type == MOUSEMOTION: # 11
##                if pygame.mouse.get_pressed() :
##                    sendOSCMsg("/hid", [ 'mousedragged', e.joy, e.button, pygame.mouse.get_pos() ]) # MOUSEMOTION
##                else : 
##                    sendOSCMsg("/hid", [ 'mousemoved', e.joy, e.button, pygame.mouse.get_pos() ]) # MOUSEMOTION

            if msg is not None :
                sendOSCMsg("/hid", msg)
                logging.info(msg)   

            if verbose : print e
            
    ## end main loop ##

    sendOSCMsg("/hid", [ 'quit' ]) #QUIT
            
    # quitting
    pygame.joystick.quit()
    pygame.quit()

    logging.info(" ----- HID server : quitting -----")
        



##def run_as_app() :
##    """ returns True when running as Windows exe/OSX app, and False when running from a script. -> boolean
##    """
##    import imp, sys
##    return (hasattr(sys, "frozen") or # new py2exe
##        hasattr(sys, "importers") # old py2exe
##            or imp.is_frozen("__main__")) # tools/freeze



if __name__ == '__main__' :
    
##    if run_as_app() :
##        # mac inserts a second argument we are not interested on
##        if sys.platform == 'darwin' : sys.argv.pop()

    print 'bundled', len(sys.argv[1:]), sys.argv[1:]
    main(*sys.argv[1:])
    
