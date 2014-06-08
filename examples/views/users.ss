{template users()}
  <h1>{@title}</h1>
  <ul>
    {forEach @users => user}
      <li>{user.name}</li>
    {end}
  </ul>
{end}