// CYLRefreshDrawnFooters: the drawn footers of iOS Custom/Drawn/CYLRefreshDrawnFooter.h (flutter_easy_refresh's
// BezierFooter, MaterialFooter, DeliveryFooter, PhoenixFooter, TaurusFooter), each a CYLRefreshDrawnFooterModel
// hosting its drawn header (iOS `+styleClass`).
import { CYLRefreshComponentAction } from '../CYLRefreshConst';
import { CYLRefreshDrawnFooterModel, CYLRefreshDrawnHeaderModel } from './CYLRefreshDrawnHeader';
import { CYLRefreshBezierRadarHeaderModel, CYLRefreshMaterialHeaderModel } from './CYLRefreshDrawnShapes';
import {
  CYLRefreshDeliveryHeaderModel,
  CYLRefreshPhoenixHeaderModel,
  CYLRefreshTaurusHeaderModel
} from './CYLRefreshDrawnVectors';

/** flutter_easy_refresh's BezierFooter, drawn by CYLRefreshBezierRadarHeader (iOS `CYLRefreshBezierRadarFooter`). */
export class CYLRefreshBezierRadarFooterModel extends CYLRefreshDrawnFooterModel {
  static footerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshBezierRadarFooterModel {
    const footer = new CYLRefreshBezierRadarFooterModel();
    footer.refreshingBlock = block;
    return footer;
  }

  newStyle(): CYLRefreshDrawnHeaderModel | null {
    return new CYLRefreshBezierRadarHeaderModel();
  }
}

/** flutter_easy_refresh's MaterialFooter, drawn by CYLRefreshMaterialHeader (iOS `CYLRefreshMaterialFooter`). */
export class CYLRefreshMaterialFooterModel extends CYLRefreshDrawnFooterModel {
  static footerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshMaterialFooterModel {
    const footer = new CYLRefreshMaterialFooterModel();
    footer.refreshingBlock = block;
    return footer;
  }

  newStyle(): CYLRefreshDrawnHeaderModel | null {
    return new CYLRefreshMaterialHeaderModel();
  }
}

/** flutter_easy_refresh's DeliveryFooter, drawn by CYLRefreshDeliveryHeader (iOS `CYLRefreshDeliveryFooter`). */
export class CYLRefreshDeliveryFooterModel extends CYLRefreshDrawnFooterModel {
  static footerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshDeliveryFooterModel {
    const footer = new CYLRefreshDeliveryFooterModel();
    footer.refreshingBlock = block;
    return footer;
  }

  newStyle(): CYLRefreshDrawnHeaderModel | null {
    return new CYLRefreshDeliveryHeaderModel();
  }
}

/** flutter_easy_refresh's PhoenixFooter, drawn by CYLRefreshPhoenixHeader (iOS `CYLRefreshPhoenixFooter`). */
export class CYLRefreshPhoenixFooterModel extends CYLRefreshDrawnFooterModel {
  static footerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshPhoenixFooterModel {
    const footer = new CYLRefreshPhoenixFooterModel();
    footer.refreshingBlock = block;
    return footer;
  }

  newStyle(): CYLRefreshDrawnHeaderModel | null {
    return new CYLRefreshPhoenixHeaderModel();
  }
}

/** flutter_easy_refresh's TaurusFooter, drawn by CYLRefreshTaurusHeader (iOS `CYLRefreshTaurusFooter`). */
export class CYLRefreshTaurusFooterModel extends CYLRefreshDrawnFooterModel {
  static footerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshTaurusFooterModel {
    const footer = new CYLRefreshTaurusFooterModel();
    footer.refreshingBlock = block;
    return footer;
  }

  newStyle(): CYLRefreshDrawnHeaderModel | null {
    return new CYLRefreshTaurusHeaderModel();
  }
}
