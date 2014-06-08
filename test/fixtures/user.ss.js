function user() {
    var __SNAKESKIN_RESULT__ = '',
        $_;
    var TPL_NAME = 'user';
    var PARENT_TPL_NAME;
    __SNAKESKIN_RESULT__ += 'Hi, ';
    __SNAKESKIN_RESULT__ += Snakeskin.Filters.html(Snakeskin.Vars['user'].name);
    __SNAKESKIN_RESULT__ += '! Its an cold cache emulation';
    return __SNAKESKIN_RESULT__;
};
if (typeof Snakeskin !== 'undefined') {
    Snakeskin.cache['user'] = user;
}