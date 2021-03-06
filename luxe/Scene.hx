package luxe;

import Luxe.Ev;
import luxe.Input;
import luxe.Screen;
import luxe.options.EntityOptions;

import luxe.Log._verboser;
import luxe.Log._verbose;
import luxe.Log._debug;
import luxe.Log.log;

class Scene extends Objects {

    public var entities : Map<String,Entity>;
    public var inited : Bool = false;
    public var started : Bool = false;

    var _delayed_init_entities : Array<Entity>;
    var _delayed_reset_entities : Array<Entity>;

    public var length(get, null) : Int = 0;

    public function new( ?_name:String='untitled scene' ) {

        super(_name);

        entities = new Map<String,Entity>();

        _delayed_init_entities = [];
        _delayed_reset_entities = [];

        Luxe.core.on(Ev.init, init);
        Luxe.core.on(Ev.destroy, _destroy);
        Luxe.core.on(Ev.update, update);

        Luxe.core.on(Ev.prerender, prerender);
        Luxe.core.on(Ev.postrender, postrender);
        Luxe.core.on(Ev.render, render);

        Luxe.core.on(Ev.keydown, keydown);
        Luxe.core.on(Ev.keyup, keyup);
        Luxe.core.on(Ev.textinput, textinput);

        Luxe.core.on(Ev.inputup, inputup);
        Luxe.core.on(Ev.inputdown, inputdown);

        Luxe.core.on(Ev.mouseup, mouseup);
        Luxe.core.on(Ev.mousedown, mousedown);
        Luxe.core.on(Ev.mousemove, mousemove);
        Luxe.core.on(Ev.mousewheel, mousewheel);

        Luxe.core.on(Ev.touchup, touchup);
        Luxe.core.on(Ev.touchdown, touchdown);
        Luxe.core.on(Ev.touchmove, touchmove);

        Luxe.core.on(Ev.gamepadup, gamepadup);
        Luxe.core.on(Ev.gamepaddown, gamepaddown);
        Luxe.core.on(Ev.gamepadaxis, gamepadaxis);
        Luxe.core.on(Ev.gamepaddevice, gamepaddevice);

        Luxe.core.on(Ev.windowmoved, windowmoved);
        Luxe.core.on(Ev.windowresized, windowresized);
        Luxe.core.on(Ev.windowsized, windowsized);
        Luxe.core.on(Ev.windowminimized, windowminimized);
        Luxe.core.on(Ev.windowrestored, windowrestored);

            //if we have already missed the internal init
        if(Luxe.core.inited) {
            init(null);
        }

    } //new

        /** add given entity to this scene */
    var entity_count : Int = 0;
    public function add( entity:Entity ) {

        if(entity == null) {
            throw "can't put entity in a scene if the entity is null.";
        }

            _debug('${name} / adding ${entity.name} with id : ${entity.id}');

        if(entities.exists(entity.name)) {
            log('${name} / adding a second entity named ${entity.name}!
                This will replace the existing one, possibly leaving the previous one in limbo.
                Use EntityOptions name_unique flag to automatically handle this for similar named entities.');
        }

        entity.scene = this;
        entities.set( entity.name, entity );
        entity_count++;


            if(inited) {
                _debug('adding a delayed entity to init list ' + entity.name);
                _delayed_init_entities.push(entity);
            } //inited

            if(started) {
                _debug('adding a delayed entity to reset list ' + entity.name);
                _delayed_reset_entities.push(entity);
            } //started

    } //add

        /** removes given entity from this scene */
    public function remove( entity:Entity ) : Bool {

        if(entity == null) {
            throw "can't remove entity from a scene if the entity is null.";
        }

        if(entity.scene == this) {

            entity.scene = null;
            entity_count--;
            return entities.remove( entity.name );

        } else {

            log("can't remove the entity from this scene, it is not mine (entity.scene != this)");
            return false;

        }

        return false;

    } //remove

        /** destroy all entities in this scene, emptying it. */
    public function empty() {

        if(entity_count > 0) {
            for(entity in entities) {
                if(entity != null) {

                    remove( entity );
                    entity.destroy();
                    entity = null;

                }
            } //each entity
        }

    } //empty

        /**
            Return a list of similarly named entities in the scene.
            For example, enemy.1 enemy.2 enemy.3 with 'enemy' will return all of these.
            Useful for the EntityOptions name_unique flag.
            Iterates all entities in the scene, use carefully.
            Note that this is a function that will likely become a part of a set of functions so it may change slightly.
            Current behavior works based on (name.)* from the beginning of the name only.
            `enemy.1` will match, `enemy` will not (no .), `this.enemy.name` will not.
            `^((?:enemy)[.]{1})`
        */
    public function get_named_like(_name:String, into:Array<Entity> ) {

        if(entity_count > 0) {
            var _filter : EReg = new EReg('^((?:' + _name + ')[.]{1})', 'g');
            for(_entity in entities) {
                if( _filter.match(_entity.name) ) {
                    into.push(_entity);
                }
            }
        }

        return into;

    } //get_named_like

//render

    function render(_) {

        emit(Ev.render);

    } //render

    function prerender(_) {

        emit(Ev.prerender);

    } //prerender

    function postrender(_) {

        emit(Ev.postrender);

    } //postrender

//Keys

    function keydown(e:KeyEvent) {

        _verboser('$name / key down / $e');

        emit(Ev.keydown, e);

    } //keydown

    function keyup(e:KeyEvent) {

        _verboser('$name / key up / $e');

        emit(Ev.keyup, e);

    } //keyup

    function textinput(e:TextEvent) {

        _verboser('$name / text event / $e');

        emit(Ev.textinput, e);

    } //textinput

//Mouse

    function mousedown(e:MouseEvent) {

        _verboser('$name / mousedown / $e');

        emit(Ev.mousedown, e);

    } //onmousedown

    function mousewheel(e:MouseEvent) {

        _verboser('$name / mousewheel / $e');

        emit(Ev.mousewheel, e);

    } //onmousewheel

    function mouseup(e:MouseEvent) {

        _verboser('$name / mouseup / $e');

        emit(Ev.mouseup, e);

    } //onmouseup

    function mousemove(e:MouseEvent) {

        _verboser('$name / mousemove / $e');

        emit(Ev.mousemove, e);

    } //onmousemove

//Touch

    function touchdown( event : TouchEvent ) {

        emit(Ev.touchdown, event);

    } //ontouchdown

    function touchup( event : TouchEvent ) {

        emit(Ev.touchup, event);

    } //ontouchup

    function touchmove( event : TouchEvent ) {

        emit(Ev.touchmove, event);

    } //ontouchmove

//Gamepad

    function gamepadaxis( event:GamepadEvent ) {

        emit(Ev.gamepadaxis, event);

    } //gamepadaxis

    function gamepadup( event:GamepadEvent ) {

        emit(Ev.gamepadup, event);

    } //gamepadup

    function gamepaddown( event:GamepadEvent ) {

        emit(Ev.gamepaddown, event);

    } //gamepaddown

    function gamepaddevice( event:GamepadEvent ) {

        emit(Ev.gamepaddevice, event);

    } //gamepaddown


//windowing

    function windowmoved( event:WindowEvent ) {

        emit(Ev.windowmoved, event);

    } //windowmoved

    function windowresized( event:WindowEvent ) {

        emit(Ev.windowresized, event);

    } //windowresized

    function windowsized( event:WindowEvent ) {

        emit(Ev.windowsized, event);

    } //windowsized

    function windowminimized( event:WindowEvent ) {

        emit(Ev.windowminimized, event);

    } //windowminimized

    function windowrestored( event:WindowEvent ) {

        emit(Ev.windowrestored, event);

    } //windowrestored

//Input

    function inputdown( event:{ _name:String, event:InputEvent } ) {

        emit(Ev.inputdown, event);

    } //oninputdown

    function inputup( event:{ _name:String, event:InputEvent }) {

        emit(Ev.inputup, event);

    } //oninputup

//Cleanup

    function _destroy(_) {

        destroy();

    } //destroy

    public function destroy() {

        Luxe.core.off(Ev.init, init);
        Luxe.core.off(Ev.destroy, _destroy);
        Luxe.core.off(Ev.update, update);

        Luxe.core.off(Ev.prerender, prerender);
        Luxe.core.off(Ev.postrender, postrender);
        Luxe.core.off(Ev.render, render);

        Luxe.core.off(Ev.keydown, keydown);
        Luxe.core.off(Ev.keyup, keyup);
        Luxe.core.off(Ev.textinput, textinput);

        Luxe.core.off(Ev.inputup, inputup);
        Luxe.core.off(Ev.inputdown, inputdown);

        Luxe.core.off(Ev.mouseup, mouseup);
        Luxe.core.off(Ev.mousedown, mousedown);
        Luxe.core.off(Ev.mousemove, mousemove);
        Luxe.core.off(Ev.mousewheel, mousewheel);

        Luxe.core.off(Ev.touchup, touchup);
        Luxe.core.off(Ev.touchdown, touchdown);
        Luxe.core.off(Ev.touchmove, touchmove);

        Luxe.core.off(Ev.gamepadup, gamepadup);
        Luxe.core.off(Ev.gamepaddown, gamepaddown);
        Luxe.core.off(Ev.gamepadaxis, gamepadaxis);
        Luxe.core.off(Ev.gamepaddevice, gamepaddevice);

        Luxe.core.off(Ev.windowmoved, windowmoved);
        Luxe.core.off(Ev.windowresized, windowresized);
        Luxe.core.off(Ev.windowsized, windowsized);
        Luxe.core.off(Ev.windowminimized, windowminimized);
        Luxe.core.off(Ev.windowrestored, windowrestored);

        emit(Ev.destroy);

    } //destroy

    function _do_init() : Bool {

        var _before_count = length;

        if(entity_count > 0) {
            for(entity in entities) {
                if(entity != null) {
                    if(!entity.inited) {
                        _verbose('calling init on an entity : ' + entity.name);
                        entity._init();
                    }
                }
            }
        }

        var _after_count = length;

        return _before_count != _after_count;

    } // _do_init

        //Entities themselves can create entities
        //inside of their init so we have to keep checking
    public function init(_) {

        var keep_going : Bool = true;
        while(keep_going) {
            keep_going = _do_init();
        }

        inited = true;

        emit(Ev.init);

        reset();

    } //init

        /** reset this scene, allowing all entities, children and attached components to be notified of the reset */
    public function reset() {

        started = false;

            emit(Ev.reset);

        started = true;

    } //reset

    function update(dt:Float) {

        Luxe.core.debug.start('scene.' + name);

            //late scene additions get init'ed and start'ed
        handle_delayed_additions();
            //just in case, as the entities are called directly
        emit(Ev.update, dt);

            //finally update them
        if(entity_count > 0) {
            for(entity in entities) {
                if(entity != null) {
                    entity._update(dt);
                }
            } //for each entity
        }

        Luxe.core.debug.end('scene.' + name);

    } //update

    function handle_delayed_additions() {

        if(_delayed_init_entities.length != 0 || _delayed_reset_entities.length != 0) {
            _debug("delayed entities in scene will init/reset now! " + _delayed_init_entities.length + ' / ' + _delayed_reset_entities.length);
        }

        if(_delayed_init_entities.length > 0) {
            for(entity in _delayed_init_entities) {
                _debug('\t handling late entity init ' + entity.name);
                entity._init();
            }
            _delayed_init_entities.splice(0, _delayed_init_entities.length);
        }

        if(_delayed_reset_entities.length > 0) {
            for(entity in _delayed_reset_entities) {
                _debug('\t handling late entity reset ' + entity.name);
                entity._reset(null);
            }
            _delayed_reset_entities.splice(0, _delayed_reset_entities.length);
        }

    } //handle_delayed_additions

    function get_length() : Int {

        return Lambda.count(entities);

    } //get_length

    function toString() {

        return 'luxe Scene: $name / $length entities / id: $id';

    } //toString


} //Scene
