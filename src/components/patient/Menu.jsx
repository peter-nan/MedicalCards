import React from 'react';
import { withStyles } from 'material-ui/styles';
import List, { ListItem, ListItemText } from 'material-ui/List';
import { History } from '../../store/index';

class Menu extends React.Component {

  go = link => History.push(link);

  render() {
    const go = this.go.bind(this);
    return (
      <List>
        <ListItem buttom='true' onClick={ go.bind(null, '/profile') }>
          <ListItemText primary='Профиль'/>
        </ListItem>
        <ListItem buttom='true' onClick={ go.bind(null, '/searchDoctor') }>
          <ListItemText primary='Найти врача'/>
        </ListItem>
        <ListItem buttom='true' onClick={ go.bind(null, '/requests') }>
          <ListItemText primary='Запросы'/>
        </ListItem>
        { /*records*/ }
      </List>
    );
  }
}

const styleSheet = {};

export default withStyles(styleSheet)(Menu);