import { useEffect, type ReactElement, type ReactNode } from 'react';
import type { StyleProp, ViewStyle } from 'react-native';
import { CYLRefreshContainer } from './CYLRefreshContainer.tsx';
import type { CYLRefreshPaging } from './paging.ts';
import { attachCYLRefreshPagingHost, cylRefreshPagingContainerProps } from './pagingContainer.ts';
import { useCYLRefreshComponent } from './useCYLRefreshComponent.ts';

/** The properties of `CYLRefreshPagingContainer`. */
export interface CYLRefreshPagingContainerProps<T> {
  /** The pager whose header and footer the native container shows; hand `paging.items` to the scroll view as usual. */
  paging: CYLRefreshPaging<T>;
  style?: StyleProp<ViewStyle>;
  /** One scroll view (`ScrollView`, `FlatList`, `SectionList`). */
  children: ReactNode;
}

/**
 * `CYLRefreshPaging` on the native container: the native header and footer do the pulling, the pager (and its JavaScript
 * header and footer) keeps loading pages and ending them. Returns null when the app has no native half
 * (`isCYLRefreshContainerAvailable()`); use `CYLRefresh` then.
 */
export function CYLRefreshPagingContainer<T>({ paging, style, children }: CYLRefreshPagingContainerProps<T>): ReactElement | null {
  useCYLRefreshComponent(paging);
  useCYLRefreshComponent(paging.header);
  useCYLRefreshComponent(paging.footer);
  useEffect(() => attachCYLRefreshPagingHost(paging), [paging]);
  return (
    <CYLRefreshContainer {...cylRefreshPagingContainerProps(paging)} style={style}>
      {children}
    </CYLRefreshContainer>
  );
}
