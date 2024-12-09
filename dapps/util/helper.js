export function cutString(str) {
    const getName = str.match(/[a-zA-Z]+/g).join('');
    const getRate = str.match(/\d+/g).join('');
    return { getName, getRate };
}

export function base64ToJson(base64String) {
    const json = Buffer.from(base64String, 'base64').toString();
    return JSON.parse(json);
}
