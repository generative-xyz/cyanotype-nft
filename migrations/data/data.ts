/*import fs from 'fs'
var data = JSON.parse(fs.readFileSync('./datajson/data-compressed.json', 'utf-8'))*/

import * as data from './datajson/data-compressed.json'

export enum ELEMENT {
    BODY = 'body',
    MOUTH = 'mouth',
    EYE = 'eye',
    HEAD = 'head',
}

const DATA_BODY = data.elements.Body
const DATA_MOUTH = data.elements.Mouth
const DATA_HEAD = data.elements.Head
const DATA_EYE =  data.elements.Eyes

export enum DNA {
    MONKEY = 'monkey',
    CAT = 'cat',
    DOG = 'dog',
    FROG = 'frog',
    ROBOT = 'robot',
    HUMAN = 'human',
}

const DATA_DNA: DNA[] = [
    DNA.MONKEY, DNA.CAT, DNA.DOG, DNA.FROG, DNA.ROBOT, DNA.HUMAN
]

const DATA_FROG_VARIANT =  data.DNA.Frog

const DATA_HUMAN_VARIANT =  data.DNA.Human

const DATA_CAT_VARIANT = data.DNA.Cat

const DATA_DOG_VARIANT =  data.DNA.Dog

const DATA_ROBOT_VARIANT = data.DNA.Robot

const DATA_MONKEY_VARIANT = data.DNA.Monkey


export {DATA_EYE, DATA_DNA, DATA_MOUTH, DATA_HEAD, DATA_FROG_VARIANT, DATA_HUMAN_VARIANT, DATA_CAT_VARIANT, DATA_DOG_VARIANT, DATA_ROBOT_VARIANT, DATA_MONKEY_VARIANT, DATA_BODY}