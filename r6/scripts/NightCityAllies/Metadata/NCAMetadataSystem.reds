module NightCityAllies.Metadata

import NightCityAllies.*
import NightCityAllies.Persistence.*

public class NCAMetadataSystem extends ScriptableSystem {
    private let m_metadata: array<ref<CompanionMetadata>>;

    public func Get(recordID: TweakDBID) -> ref<CompanionMetadata> {
        let index: Int32 = this.GetIndex(recordID);
        if index >= 0 {
            return this.m_metadata[index];
        }

        return this.Collect(recordID);
    }

    public func GetFromString(record: String) -> ref<CompanionMetadata> {
        return this.Get(TDBID.Create(record));
    }

    public func Collect(recordID: TweakDBID) -> ref<CompanionMetadata> {
        let collected: ref<CompanionMetadata> = CompanionMetadata.Create(recordID);

        let index: Int32 = this.GetIndex(recordID);
        if index >= 0 {
            this.m_metadata[index] = collected;
        } else {
            ArrayPush(this.m_metadata, collected);
        }

        return collected;
    }

    public func CollectAppearances(recordID: TweakDBID) -> Bool {
        let metadata: ref<CompanionMetadata> = this.Get(recordID);
        if metadata.HasAppearances() {
            return true;
        }

        let token: ref<ResourceToken> = GameInstance.GetResourceDepot().LoadResource(metadata.entityTemplatePath);
        if !token.IsLoaded() {
            return false;
        }

        metadata.TakeAppearances(token.GetResource() as entEntityTemplate);
        return metadata.HasAppearances();
    }

    private func GetIndex(recordID: TweakDBID) -> Int32 {
        let i: Int32 = 0;
        while i < ArraySize(this.m_metadata) {
            if Equals(this.m_metadata[i].recordID, recordID) {
                return i;
            };
            i += 1;
        };
        return -1;
    }
}
