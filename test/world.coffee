#!/usr/bin/env coffee
{ World } = require '../dist/world'

tap = require 'tap'

w = new World()

tap.ok(w)
