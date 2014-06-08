{template index(title = 'SS express demo')}
  <h1>{title}</h1>
  {block sub}
    <p>Welcome to the {title} demo. Click a link:</p>
    <ul>
      <li><a href="/users">/users</a></li>
    </ul>
  {end}
{end}