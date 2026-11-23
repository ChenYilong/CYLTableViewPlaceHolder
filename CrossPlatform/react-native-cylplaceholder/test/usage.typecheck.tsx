// Type-checked only (`tsc`): the way an app spreads CYLRefresh's props onto a ScrollView and a FlatList.
import { FlatList, ScrollView, Text } from 'react-native';
import { CYLRefresh, CYLRefreshClassicAutoFooter, CYLRefreshClassicHeader } from '../src/index.tsx';

const header = new CYLRefreshClassicHeader({ refreshingHandler: () => header.endRefreshing() });
const footer = new CYLRefreshClassicAutoFooter({ refreshingHandler: () => footer.endRefreshing() });

export function ScrollViewExample() {
  return <CYLRefresh header={header}>{(props) => <ScrollView {...props}><Text>row</Text></ScrollView>}</CYLRefresh>;
}

export function FlatListExample() {
  return (
    <CYLRefresh header={header} footer={footer} refreshOnStart>
      {(props) => <FlatList {...props} data={[1, 2, 3]} keyExtractor={(n) => String(n)} renderItem={({ item }) => <Text>{item}</Text>} />}
    </CYLRefresh>
  );
}
