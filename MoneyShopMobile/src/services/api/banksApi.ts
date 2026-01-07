import {apiClient} from './apiClient';

export interface Bank {
  id: number;
  name: string;
  commissionPercent: number;
  active: boolean;
}

export const banksApi = {
  async getAll(): Promise<Bank[]> {
    const response = await apiClient.get<Bank[]>('/banks');
    return response.data;
  },

  async getById(id: number): Promise<Bank> {
    const response = await apiClient.get<Bank>(`/banks/${id}`);
    return response.data;
  },
};

