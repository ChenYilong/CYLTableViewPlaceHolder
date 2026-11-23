// Type-checked only (`tsc`): the way an app spreads CYLRefresh's props onto a ScrollView and a FlatList.
import { FlatList, ScrollView, Text } from 'react-native';
import { CYLRefresh, CYLRefreshClassicAutoFooter, CYLRefreshClassicHeader, CYLRefreshContainer } from '../src/index.tsx';

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

// The native container with its footer: load more and no more data, driven by props like the header's `refreshing`.
export function NativeContainerExample({ loading, done, more }: { loading: boolean; done: boolean; more: () => void }) {
  return (
    <CYLRefreshContainer refreshing={false} onRefresh={() => {}} loadMoreEnabled loadingMore={loading} noMoreData={done} onLoadMore={more}>
      <FlatList data={[1, 2, 3]} keyExtractor={(n) => String(n)} renderItem={({ item }) => <Text>{item}</Text>} />
    </CYLRefreshContainer>
  );
}
