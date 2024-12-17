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
    MONKEY = 'Monkey',
    CAT = 'Cat',
    DOG = 'Dog',
    FROG = 'Frog',
    ROBOT = 'Robot',
    HUMAN = 'Human',
}

const KEY_DNA = [DNA.CAT, DNA.DOG, DNA.FROG, DNA.ROBOT, DNA.HUMAN, DNA.MONKEY]
const TRAITS_DNA = [data.DNA.Cat.trait, data.DNA.Dog.trait, data.DNA.Frog.trait, data.DNA.Robot.trait, data.DNA.Human.trait,data.DNA.Monkey.trait].map((item) => Number(item))

const DATA_DNA = [
    {
        key: DNA.CAT,
        trait: data.DNA.Cat.trait,
    },
    {
        key: DNA.DOG,
        trait: data.DNA.Dog.trait,
    },
    {
        key: DNA.FROG,
        trait: data.DNA.Frog.trait,
    },
    {
        key: DNA.ROBOT,
        trait: data.DNA.Robot.trait,
    },
    {
        key: DNA.HUMAN,
        trait: data.DNA.Human.trait,
    },
    {
        key: DNA.MONKEY,
        trait: data.DNA.Monkey.trait,
    },
]

// const DATA_FROG_VARIANT =  data.DNA.Frog.items
//
// const DATA_HUMAN_VARIANT =  data.DNA.Human.items
//
// const DATA_CAT_VARIANT = data.DNA.Cat.items
//
// const DATA_DOG_VARIANT =  data.DNA.Dog.items
//
// const DATA_ROBOT_VARIANT = data.DNA.Robot.items
//
// const DATA_MONKEY_VARIANT = data.DNA.Monkey.items


// export {DATA_EYE, DATA_DNA, DATA_MOUTH, DATA_HEAD, DATA_FROG_VARIANT, DATA_HUMAN_VARIANT, DATA_CAT_VARIANT, DATA_DOG_VARIANT, DATA_ROBOT_VARIANT, DATA_MONKEY_VARIANT, DATA_BODY}

export {KEY_DNA, TRAITS_DNA}