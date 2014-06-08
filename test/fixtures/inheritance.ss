{template childTemplate()}{name='World'}Hello, {name}!{end}

{template inheritance() extends childTemplate}
  {name='World'}
{end}